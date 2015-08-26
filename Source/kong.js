// Load the API
// var kongregate;
kongregateAPI.loadAPI(onComplete);
var loaded = false;
var submitThese = [];

// Callback function
function onComplete(){
  // Set the global kongregate API object
  kongregate = kongregateAPI.getAPI();
  loaded = true;
  for(i in submitThese)
  {
    kongSubmit(submitThese[i].stat,submitThese[i].amount);
    submitThese = [];
  }
}

function kongSubmit(stat,amount)
{
    if(loaded)
    {
        kongregate.stats.submit(stat,amount);
    }
    else
    {
        submitThese.push({stat:stat,amount:amount});
    }
}