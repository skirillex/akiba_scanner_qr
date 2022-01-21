#!/usr/bin/env python

import asyncio
import websockets
import qr_reader


async def echo(websocket, path):
    print("started server")
    async for message in websocket:
        await websocket.send(message)
        print(message)

        if message == "scan_and_sort":
            qr_reader.add_filenames_to_excel()


start_server = websockets.serve(echo, "0.0.0.0", 49985)  # 56095)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()
