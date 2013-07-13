/*{"type":"set","name":"control_list","function":"return ['mousemove','click','dblclick','keydown','keypress','keyup'];"}*/STOP

/*{"type":"set","name":"control_index","function":"return 0;"}*/STOP


/*{"type":"record","name":"control_section","end_label":"end_control_section"}*/STOP


/*{"type":"set","name":"current_control","function":"return m['control_list'][m['control_index']];"}*/STOP

canvas.addEventListener(/*{"type":"get","name":"current_control","prefix":"\"","suffix":"\""}*/STOP, function(e){
     //e variables:  pageX, pageY
});

/*{"type":"switch","test_function":"return 0 if control_index == 0; return m['control_index']<m['control_list'].size","result_label_hash":"{true:"repeat",false:"exit",0:"end_control_section"}"}*/STOP

/*{"type":"label","name":"repeat"}*/STOP
/*{"type":"play","name":"control_section"}*/STOP

/*{"type":"label","name":"end_control_section"}*/STOP
/*{"type":"play","name":"control_section"}*/STOP

/*{"type":"label","name":"exit"}*/STOP

//You should only see this once
