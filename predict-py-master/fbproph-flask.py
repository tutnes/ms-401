import dcrum
import predict
from flask import Flask, Response, request, jsonify
from flask_restful import reqparse, abort, Api, Resource
from createumeasures import createumeasures

import json

app = Flask(__name__)
api = Api(app)


parser = reqparse.RequestParser()
parser.add_argument('data',type=dict, help='Main data object')


# Todo
# The Fbprophet class, it takes a DCRUM REST response, and returns the prediction, with or without the historic data
@app.route('/fbprophet',methods=['GET','POST'])
def fbprophet():
    dcrumdata = None
    if request.method == 'GET':
        # For getting examples
        dcrumdata = dcrum.get_dcrum()
    if request.method == 'POST':
        # For actual input
        dcrumdata = json.loads(request.data)

    # Gets the parameters from the URL, and if they are not set, sets them to their defaults

    # Number of periods defaults to 5
    periods = request.args.get('periods', default = 5, type = int)
    returnformat = request.args.get('returnformat', default = "u_measures", type = str)
    # Gets the include history as a string, otherwise it will not behave as expected
    include_history_str = request.args.get('include_history', default = 'True', type = str)
    include_history = True
    if (include_history_str.lower() == 'true'): # To make sure, we check against the lowercase version
        include_history = True
    
    # Gets the frequency of the timeperiods
    freq = request.args.get('freq', default = '5min', type = str)
    
    # If we are not going to use the "Operations" metric as the one being predicted on, take a a parameter as columnid and use this instead
    columnid = request.args.get('columnid', default = 'Operations', type = str)
    # The actual invocation of the prediction part, returns a pandas object

    prediction = predict.get(dcrumdata,periods=periods,include_history=include_history,freq=freq, columnid=columnid)
    
    # Creates a dict for handling the json variant of the pandas object, unless the date format will be strange    
    pred_json = prediction.to_json()
    pred = dict()
    pred['prediction'] = json.loads(pred_json)
    pred['parameters'] = dict(periods=periods,include_history=include_history,freq=freq, columnid=columnid)
    
    
    # Returns the jsonifed dictionary
    if (returnformat != "u_measures"):
        return jsonify(pred)
    else:
        u_measures = createumeasures(pred)
        return u_measures



if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
