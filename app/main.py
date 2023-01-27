import sys
print("path:", sys.path)

import pymc

#print("hello world!")
print("found pymc ", pymc.__version__)

from fastapi import FastAPI

app = FastAPI()


@app.get("/")
async def root():
    return {"message": "Hello World", "pymc-version": pymc.__version__}

