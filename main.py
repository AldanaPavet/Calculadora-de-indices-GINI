import requests
import ctypes

url = "https://api.worldbank.org/v2/en/country/all/indicator/SI.POV.GINI?format=json&date=2011:2020&per_page=32500&page=1&country=%22Argentina%22"
response = requests.get(url)

if response.status_code == 200:
    data = response.json()
else:
    print(response.status_code)

while True:
    target_year = input("Ingrese un año entre 2011 y 2020: ")

    if target_year.isdigit():  # Verificar si la entrada es un número
        if 2011 <= int(target_year) <= 2020:  # Verificar si el año está dentro del rango deseado
            break
        else:
            print("El año ingresado no está dentro del rango especificado.")
    else:
        print("Entrada inválida. Por favor, ingrese un número.")

target_country = 'Argentina'
for item in data[1]:
    if item['country']['value'] == target_country and item['date'] == target_year:
        gini = item['value']    # type: float or None
        # print(gini)
        # print(type(gini))
        break

#carga la biblioteca compartida
# cLibrary = ctypes.CDLL('/home/david/CLionProjects/untitled/libftoi.so')
cLibrary = ctypes.CDLL('./libftoi.so')
# c_float_to_int = cLibrary.cFloatToInt

#establece el tipo de argumento de la función
cLibrary.cFloatToInt.argtypes = [ctypes.c_float]
#establece el tipo de retorno de la función
cLibrary.cFloatToInt.restype = ctypes.c_int

def c_float_to_int(flotante):
    return cLibrary.cFloatToInt(flotante)

if gini is not None:
    print(c_float_to_int(gini))
else:
    print("El valor del año 2015 no está disponible")
