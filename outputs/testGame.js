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
},  /*{"type":"request","name":"draw","prompt":"specify draw interval (integer > 0)",
"validation_function":"return s.to_i>0","processing_function":"return"}*//*{\"type\":\"request\",\"name\":\"draw\",\"prompt\":\"specify draw interval (integer > 0)\",\"validation_function\":\"return s.to_i>0\",\"processing_function\":\"return\"}*/
"30"/*{\"type\":\"get\",\"name\":\"draw\",\"prefix\":\"\\"\",\"suffix\":\"\\"\"}*/);
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
},  /*{"type":"request","name":"update","prompt":"specify update interval (integer > 0)",
"validation_function":"return s.to_i>0","processing_function":"return"}*//*{\"type\":\"request\",\"name\":\"update\",\"prompt\":\"specify update interval (integer > 0)\",\"validation_function\":\"return s.to_i>0\",\"processing_function\":\"return\"}*/
"10"/*{\"type\":\"get\",\"name\":\"update\",\"prefix\":\"\\"\",\"suffix\":\"\\"\"}*/);

function update()
{
    //call update on each object
    for e in activeEntities
    {
        e.update();
    }
}
/*{\"type\":\"set\",\"name\":\"control_list\",\"function\":\"return ['mousemove','click','dblclick','keydown','keypress','keyup'];\"}*/

/*{\"type\":\"set\",\"name\":\"control_index\",\"function\":\"return 0;\"}*/


/*{\"type\":\"record\",\"name\":\"control_section\",\"end_label\":\"end_control_section\"}*/


/*{\"type\":\"set\",\"name\":\"current_control\",\"function\":\"return m['control_list'][m['control_index']];\"}*/

canvas.addEventListener(/*{"type":"get","name":"current_control","prefix":"\"","suffix":"\""}*/, function(e){
     //e variables:  pageX, pageY
});

/*{\"type\":\"switch\",\"test_function\":\"return 0 if control_index == 0; return m['control_index']<m['control_list'].size\",\"result_label_hash\":\"{true:\"repeat\",false:\"exit\",0:\"end_control_section\"}\"}*/

/*{\"type\":\"label\",\"name\":\"repeat\"}*/