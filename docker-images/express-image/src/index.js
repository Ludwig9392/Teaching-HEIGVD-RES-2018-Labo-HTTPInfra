var Chance = require('chance');
var chance = new Chance();

var Express = require('express');
var app = Express();

app.get('/', function(req, res) {
    res.send(generateFunnyPeople());
});

app.listen(3000, function() {
    console.log('Accepting HTTP requests on port 3000!');
});
 
function generateFunnyPeople(){
	var numberOfPeople = chance.integer({
		min : 1,
		max : 10
	});
	
	console.log(numberOfPeople);
	
	var peoples = [];
	
	for(var i = 0; i < numberOfPeople; ++i){
        var gender = chance.gender();
		peoples.push({
            
            'first'   : chance.first({ gender: gender }),
            'last'    : chance.last(),
            'gender'  : gender,
            'country' : chance.country({ full: true }),
            'profession' : chance.profession({rank: true}),
            'company' : chance.company(),
            'email' : chance.email(),
            'pet' : chance.animal(),
		});
	}
	console.log(peoples);
	return peoples;
}
