import asyncio


async def sleep():
    while True:
        await asyncio.sleep(1)

asyncio.run(sleep())
