metaController = {
didComplete:function(){
    gameState = null;
    
    window.webkit.messageHandlers.mediator.postMessage({"action":"complete"});
    
},
};