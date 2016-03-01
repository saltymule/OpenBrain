metaController = {
didComplete:function(options, message){
    window.webkit.messageHandlers.mediator.postMessage({"action":"complete","options":options,"message":message});
},
didLoad:function(){
    window.webkit.messageHandlers.mediator.postMessage({"action":"load"});
}
};
