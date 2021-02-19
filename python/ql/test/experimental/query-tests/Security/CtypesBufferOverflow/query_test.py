import ctypes

from flask import Flask, request
app = Flask(__name__)


@app.route("/test")
def test():
    user_input = request.args.get('user-input')

    ctypes.c_double.from_param(user_input)
    ctypes.c_double.from_param(float(user_input))

    ctypes.c_float.from_param(user_input)
    ctypes.c_float.from_param(float(user_input))
