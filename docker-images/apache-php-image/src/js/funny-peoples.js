$(function() {
    console.log("Loading peoples");

    function loadPeoples() {
            $.getJSON( "/api/peoples/", function( peoples ) {
                    console.log(peoples);
                    var name = "No one's here";
                    var gender = "No one's here";
                    var nationality = "No one's here";
                    var job = "No one's here";
                    var pet = "No one's here";
                    if( peoples.length > 0 ) {
                            name = peoples[0].first + " " + peoples[0].last;
                            gender = peoples[0].gender;
                            nationality = peoples[0].country;
                            job = peoples[0].profession + " - " + peoples[0].company;
                            pet = peoples[0].pet;
                    }
                    $(".name").text(name);
                    $(".gender").text(gender);
                    $(".nation").text(nationality);
                    $(".job").text(job);
                    $(".pet").text(pet);
            });
    };

    loadPeoples();
    setInterval( loadPeoples, 7000 );
});
