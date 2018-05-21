import pandas as pd

#Import the predictive library from facebook
import fbprophet



# Gets the data from DCRUM as JSON, and returns the forecast
def get(data,**parameters):
        # Checks for periods sent in parameters, if its not set it do a default value
        print(parameters)
        if('periods' in parameters):
            periods = parameters['periods']
        # Checks for include_history sent in parameters, if its not set it do a default value
        if('include_history' in parameters):
            include_history = parameters['include_history']
        else:
            include_history = False
        # Checks for frequency sent in parameters, if its not set it do a default value
        if('freq' in parameters):
            freq = parameters['freq']
        else:
            freq='5min'
        # Checks for columnid sent in parameters, if its not set it do a default value
        if('columnid' in parameters):
            columnid = parameters['columnid']
        else:
            columnid='Operations'
        
        # creates a pandas object with the rawData from the DCRUM data
        indata = pd.DataFrame(data['rawData'],columns=data['columnHeaderName'],)
        # parses the epoch time in milliseconds to a pandas time format
        indata['Time'] = pd.to_datetime(indata['Time'],unit='ms')
        # Renames columnheaders to something that Fbprophet likes
        indata = indata.rename(columns={'Time': 'ds', columnid: 'y'})
        # Create a prophet object
        m = fbprophet.Prophet(changepoint_prior_scale=0.01)
        
        # Fit the prophet object to the indata
        m.fit(indata)
        
        # Make a future dataframe with 10 periods and 5 minute frequency, do not include history in the timeframe
        future = m.make_future_dataframe(periods=periods, freq=freq, include_history=include_history)
        
        # Create the forecast
        forecast = m.predict(future)
              
        
        # return the forecast
        return forecast
