from flask import jsonify




def createumeasures(pred):
    
    #Initializes the u_measures object
    u_measures = dict(u_measures = [])
    
    # gets the columnid from the parameters
    columnid = pred['parameters']['columnid']
    
    # Iterates through the prediction object and creates the u_measures return object
    for index in pred['prediction']['yhat']:
    	time = pred['prediction']['ds'][index] 
    	yhat = pred['prediction']['yhat'][index]
    	yhat_lower = pred['prediction']['yhat_lower'][index]
    	yhat_upper = pred['prediction']['yhat_upper'][index]
    	u_measures['u_measures'].append(dict(time = time, name = columnid, yhat_lower = yhat_lower, yhat_upper = yhat_upper, yhat = yhat))
    # returns the json of the u_measures object
    return jsonify(u_measures)