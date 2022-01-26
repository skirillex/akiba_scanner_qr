#!/usr/bin/env python

import asyncio
import websockets
import qr_reader
import json


async def echo(websocket):
    print("started server")
    async for message in websocket:
        await websocket.send("Server Connection Successful")
        data = json.loads(message)


        if data['command'] == "scan_and_sort":
            await websocket.send("Scanning images...")
            qr_reader.add_filenames_to_excel(input_path=data['inputPath'],
                                             output_path=data['outputPath'],
                                             excel_path=data['excelPath'])
            await websocket.send("File locations: \n"
                                 f"Input: {data['inputPath']} \n"
                                 f"Output: {data['outputPath']} \n"
                                 f"Excel file: {data['excelPath']}")


start_server = websockets.serve(echo, "0.0.0.0", 49985)  # 56095)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()
