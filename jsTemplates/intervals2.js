setInterval(function() {
    animate(canvas, context);
},  /*{"type":"request","name":"draw","prompt":"specify draw interval (integer > 0)",
"validation_function":"return s.to_i>0","processing_function":"return"}*/STOP
/*{"type":"get","name":"draw","prefix":"\"","suffix":"\""}*/STOP);
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
"validation_function":"return s.to_i>0","processing_function":"return"}*/STOP
/*{"type":"get","name":"update","prefix":"\"","suffix":"\""}*/STOP);

function update()
{
    //call update on each object
    for e in activeEntities
    {
        e.update();
    }
}
