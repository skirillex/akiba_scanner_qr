#!/usr/bin/env python

import asyncio
import websockets

async def echo(websocket, path):
    print("started server")
    async for message in websocket:
        await websocket.send(message)
        print(message)

start_server = websockets.serve(echo, "0.0.0.0", 49875)#56095)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()