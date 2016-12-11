import websocket
import thread
import time
import calendar
import json

# Global variables
PAYLOADS = []


def on_message(ws, message):
    if json.JSONDecoder().decode(message)["statusCode"] != 202:
        print("Error sending packet to time-series service")
        print(message)
        # sys.exit(1)
    else:
        print("Packet Sent")


def on_error(ws, error):
    print(error)


def on_close(ws):
    print("--- Socket Closed ---")


def prepareData(payloads, data):
    records = json.load(data)

    dpsize = len(records['records'])
    m = 1
    datapoints = []
    meter = ""

    meter = records['links'][0]['href'].split('/')[7]
    print("Generating packets with " + str(dpsize) + " data points...")

    for record in records['records']:
        rc = record['record']
        tstamp = calendar.timegm(time.strptime(rc['fields']['timestamp'], '%Y-%m-%dT%H:%M:%S+00:00')) * 1000
        value = float(rc['fields']['value'])
        datapoints.append([tstamp, value, 3])
        if (len(datapoints) > 5000):
            payloads.append(payload(meter, datapoints, m + 1))
            datapoints = []

    if (len(datapoints) > 0):
        payloads.append(payload(meter, datapoints, m + 1))

    return payloads


def payload(meter, datapoints, m):
    datapointsstr = ""
    for d in datapoints:
        datapointsstr += "[" + str(d[0]) + "," + str(d[1]) + "," + str(3) + "],"

    datapointsstr = datapointsstr[:-1]

    payload = '''{  
                   "messageId": ''' + str(m) + ''',
                   "body":[  
                      {  
                         "name":"''' + meter + '''",
                         "datapoints": [''' + datapointsstr + '''],
                         "attributes":{  
                         }
                      }
                   ]
                }'''
    return payload


def sendPayload(ws):
    global PAYLOADS
    print("--- Socket Opened ---")

    def run(*args):
        i = 0
        it = len(PAYLOADS)
        for p in PAYLOADS:
            i += 1
            ws.send(p)
            print("Sending packet " + str(i) + " of " + str(it))
            time.sleep(1)

        time.sleep(1)
        ws.close()
        print(str(i) + " packets sent.")
        print("Thread terminating...")

    thread.start_new_thread(run, ())


def openWSS(uaaToken, tsUri, tsZone, origin):
    websocket.enableTrace(False)
    host = tsUri
    headers = {
        'Authorization:bearer ' + uaaToken,
        'Predix-Zone-Id:' + tsZone,
        'Origin:' + origin
    }
    ws = websocket.WebSocketApp(
        host,
        header=headers,
        on_message=on_message,
        on_error=on_error,
        on_close=on_close
    )
    ws.on_open = sendPayload
    ws.run_forever()
