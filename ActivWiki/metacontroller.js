metaController = {
didComplete:function(options){
    window.webkit.messageHandlers.mediator.postMessage({"action":"complete","options":options});
},
didLoad:function(){
    window.webkit.messageHandlers.mediator.postMessage({"action":"load"});
}
};
