setInterval(function() {
    animate(canvas, context);
},  /*{"type":"paramater","prompt":"specify draw interval (integer > 0)",
"validate":"def validate(s);
            return s.to_i>0;
            end",
"prefix":"\"","suffix":"\""}*/STOP);
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
"prefix":"\"","suffix":"\""}*/STOP);

function update()
{
    //call update on each object
    for e in activeEntities
    {
        e.update();
    }
}
