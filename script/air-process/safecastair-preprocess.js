/**
 * Preprocessor for Safecast air logs
 *
 * Takes 2 arguments:
 * - configuration file
 * - Log file
 *
 * outputs a new log file, enriched with the IDs
 */

var fs = require('fs');
var jsonfile = require('jsonfile');
var rl = require('readline');

var myArgs = process.argv.slice(2);

if (myArgs.length != 2) {
    console.log("Needs two args");
    process.exit();
}

// Read the config files
var config = jsonfile.readFileSync(myArgs[0]);

// We need to read the log line by line because it's not proper JSON, but
// rather a successful of JSON structures, line by line

var log = rl.createInterface({
    input: fs.createReadStream(myArgs[1])
});
// Then parse and enrich, line by line
log.on('line', function (line) {
    var jline = JSON.parse(line);
    var processed_line = {
        dev: jline.dev,
        id: jline.id,
        msg: jline.msg,
        gps: jline.gps,
        gas: [],
        tmp: [],
        pm: []
    };
    
    // Fix the date (the firmware has a bug that forgets leading zeroes
    // on values < 10
    var bad_date = jline.gps.date;
    var spl = bad_date.indexOf('T');
    var ymd = bad_date.substr(0,spl).split('-');
    var hms = bad_date.substr(spl+1, bad_date.length-spl-2).split(':');
    processed_line.gps.date = ymd[0] + '-' + ((ymd[1] < 10) ? '0': '') + ymd[1] + '-' +
        ((ymd[2]<10) ? '0' : '') + ymd[2] + 'T' +
        ((hms[0] < 10) ? '0':'') +hms[0] + ':' + ((hms[1] < 10) ? '0': '') + hms[1] + ':' +
        ((hms[2]<10) ? '0' : '') + hms[2] + 'Z';
        
        ;
    
    // Fix the GPS coordinates to use simple decimal degrees
    var bad_lat = parseFloat(jline.gps.lat.substr(0,jline.gps.lat.length-1));
    processed_line.gps.lat = bad_lat/100 * ((jline.gps.lat.charAt(jline.gps.lat.length-1) == 'N') ? 1 : -1);
    var bad_lon = parseFloat(jline.gps.lon.substr(0,jline.gps.lon.length-1));
    processed_line.gps.lon = bad_lon/100 * ((jline.gps.lon.charAt(jline.gps.lon.length-1) == 'E') ? 1 : -1);
    
    
//    processed_line.gps.lat = 
    
    for (sensor in jline.gas) {
        var s = jline.gas[sensor]
        if (s.hdr == 0) {
            switch (s.pos) {
                case 0:
                    s['ids'] = config.gas.header0.pos0;
                    break;
                case 1:
                    s['ids'] = config.gas.header0.pos1;
                    break;  
                case 2:
                    s['ids'] = config.gas.header0.pos2;
                    break;
            }
        } else if (s.hdr == 1) {
            switch (s.pos) {
                case 0:
                    s['ids'] = config.gas.header1.pos0;
                    break;
                case 1:
                    s['ids'] = config.gas.header1.pos1;
                    break;  
                case 2:
                    s['ids'] = config.gas.header1.pos2;
                    break;
            }
        } else if (s.hdr == 2) {
            switch (s.pos) {
                case 0:
                    s['ids'] = config.gas.header2.pos0;
                    break;
                case 1:
                    s['ids'] = config.gas.header2.pos1;
                    break;  
                case 2:
                    s['ids'] = config.gas.header2.pos2;
                    break;
            }
        }
        processed_line.gas.push(s);
    }
    for (tmp in jline.tmp) {
        var t = jline.tmp[tmp];
        if (t.hdr == 0)
            t.ids = config.tmp.header0;
        if (t.hdr == 1)
            t.ids = config.tmp.header1;
        processed_line.tmp.push(t);
    }

    // Right now, we will assume we have one and only one PM sensor (there is nothing in the
    // file which tells us about header information
    if (jline.pm.length != 1) {
        console.log('PM Error: found multiple entries for PM sensor, we only expect one');
        process.exit();
    }
    jline.pm[0]['ids'] = config.pm;
    processed_line.pm.push(jline.pm[0]);
    
    console.log(JSON.stringify(processed_line));

});
