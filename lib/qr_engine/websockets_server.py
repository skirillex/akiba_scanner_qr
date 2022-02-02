#!/usr/bin/env python

import asyncio
import websockets
import qr_reader
import qr_code
import json
import sys
import os

port = 49985
try:
    port = int(os.getenv('AKIBA_PORT'))
except:
    port = 49985

if __name__ == "__main__":
    if len(sys.argv)>1:
        port = int(sys.argv[1])


print(port)

async def echo(websocket):
    print("started server")
    print(port)
    async for message in websocket:
        await websocket.send("Server Connection Successful")
        data = json.loads(message)

        if data['command'] == 'ping':
            await websocket.send("Ready")
        if data['command'] == "scan_and_sort":
            await websocket.send("File locations: \n"
                                 f"Input: {data['inputPath']} \n"
                                 f"Output: {data['outputPath']} \n"
                                 f"Excel file: {data['excelPath']}")

            await qr_reader.add_filenames_to_excel(input_path=data['inputPath'],
                                             output_path=data['outputPath'],
                                             excel_path=data['excelPath'],
                                             websocket=websocket)
            
        if data['command'] == "generate_qr":
            await websocket.send("Generating QR Codes")
            qr_code.generate_qr(output_path=data['outputPath'],
                                num_of_qr=data['numOfQr'])
    print(port)
    #websocket.close()


start_server = websockets.serve(echo, "0.0.0.0", port, ping_interval=None)  # 56095)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()
