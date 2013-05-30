/*begin statics.js*/
window.requestAnimFrame = (function(callback) {
        return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame ||
        function(callback) {
          window.setTimeout(callback, 1000 / 60);
        };
})();

var canvas = document.getElementById("canvas");
var context = canvas.getContext("2d");

var activeEntities = [];
var passiveEntities = [];

function addActiveEntity(e)
{
    acitveEntities.append(e);
}

function addPassiveEntity(e)
{
    passiveEntities.append(e);
}
/*end statics.js*/


/*set intervals.js*/
setInterval(function() {
    animate(canvas, context);
},  PARAM);

function animate(canvas, context)
{
    context.clearRect(0,0,canvas.width,canvas.height);
    for e in activeEntities
    {
        e.draw();
    }
    
    for e in activeEntities
    {
        e.draw();
    }
}


setInterval(function() {
    update();
},  PARAM);

function update()
{
    //call update on each object
    for e in activeEntities
    {
        e.update();
    }
}
/*end intervals.js*/

/*other templates*/

/*start controls.js*/
canvas.addEventListener("mousemove", function(e){
    //e variables:  pageX, pageY
});

canvas.addEventListener("click", function(e){
     //e variables:  pageX, pageY
});

canvas.addEventListener("dblclick", function(e){
     //e variables:  pageX, pageY
});

canvas.addEventListener("keydown", function(e){
     //e variables:  pageX, pageY
});

canvas.addEventListener("keypress", function(e){
     //e variables:  pageX, pageY
});

canvas.addEventListener("keyup", function(e){
     //e variables:  pageX, pageY
});
/*end controls.js*/
