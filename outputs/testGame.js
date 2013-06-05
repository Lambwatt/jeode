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

setInterval(function() {
    animate(canvas, context);
},  /*{"type":"paramater","prompt":"specify draw interval (integer > 0)",
"validate":"def validate(s);
            return s.to_i>0;
            end",
"prefix":"\"","suffix":"\""}*/"30");
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
},  /*{"type":"paramater","prompt":"specify update interval (integer > 0)",
"validate":"def validate(s);
            return s.to_i>0;
            end",
"prefix":"\"","suffix":"\""}*/"10");

function update()
{
    //call update on each object
    for e in activeEntities
    {
        e.update();
    }
}
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
