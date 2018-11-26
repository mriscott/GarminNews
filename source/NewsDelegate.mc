//
// Copyright 2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.Communications as Comm;
using Toybox.WatchUi as Ui;

class NewsDelegate extends Ui.BehaviorDelegate {
    var notify;
    var max=15;
    var index=0;
    var noheadlines=0;
    var headlines=new [max*2];
	var url= "https://newsapi.org/v2/top-headlines?apiKey=8db66d1523c843528d6b6d84a4aa4f7a&sources=bbc-news";

    // Handle menu button press
    function onMenu() {
        nextStory();
        return true;
    }

    function onSelect() {
        nextStory();
        return true;
    }
    

    function nextStory() {
        if(noheadlines==0) {
	   getNews();
	} else {
	    notify.invoke(headlines[index]);
	    index++;
	    if(index==noheadlines) { 
		    index=0;
		    Attention.vibrate([new Attention.VibeProfile(100,200)]);

	    }
	}
    }

    function getNews(){
        if(System.getDeviceSettings().phoneConnected){
        notify.invoke("Getting\nHeadlines");
        Comm.makeWebRequest(
             url,
            {
            },
            {
                "Content-Type" => Comm.REQUEST_CONTENT_TYPE_JSON
            },
            method(:onReceive)
        );

	}  else {
	   notify.invoke("Phone\ndisconnected");
	}

    }

    // Set up the callback to the view
    function initialize(handler) {
        Ui.BehaviorDelegate.initialize();
        notify = handler;
	getNews();
    }

    // Receive the data from the web request
    function onReceive(responseCode, data) {
        if (responseCode == 200) {
		if(data instanceof Dictionary) {
		    notify.invoke("Processing");
		    var articles=data.get("articles");
		    noheadlines=0;
		    for(var i=0;i<articles.size();i++){
		       if((noheadlines+2)<=max){
		       	    if(articles[i] instanceof Dictionary){
			    headlines[noheadlines]=articles[i].get("title")+"...";
			    noheadlines++;
			    headlines[noheadlines]="... "+articles[i].get("description");
			    noheadlines++;
			    }
		       }
		    }
		     Attention.vibrate([new Attention.VibeProfile(100,500)]);
		    nextStory();
		} else {
			notify.invoke("Bad response");
			}
        } else {
            notify.invoke("Failed to load\nError: " + responseCode.toString());
        }
    }
}
