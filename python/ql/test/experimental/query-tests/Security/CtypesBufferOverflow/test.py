import ctypes
import multiprocessing
import importlib

# it's OK to create a double, the problem arises when using the `repr` function
ctypes.c_double.from_param(1e300)

def test_double():
    double = ctypes.c_double.from_param(1e300)
    repr(double)

def test_double_str():
    double = ctypes.c_double.from_param(1e300)
    str(double)

def test_double_print():
    double = ctypes.c_double.from_param(1e300)
    print(double)

def test_double_str_arg():
    double = ctypes.c_double.from_param('1e300')
    repr(double)

def test_double_float_arg():
    double = ctypes.c_double.from_param(float('1e300'))
    repr(double)

def test_float():
    float = ctypes.c_float.from_param(1e300)
    repr(float)

def test_float():
    float = ctypes.c_float
    repr(float)

if __name__ == '__main__':

    functions = []

    mod = importlib.import_module(__file__.split('/')[-1].strip('.py'))
    for item_name in dir(mod):
        if not item_name.startswith("test_"):
            continue
        item = getattr(mod, item_name)
        if callable(item):
            functions.append(item)

    for func in functions:
        print(func)
        p = multiprocessing.Process(target=test_1)
        p.start()
        p.join()
        if not p.exitcode == -6:
            print("Did not overflow")
