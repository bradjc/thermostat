var socket;
var g;

var fields = ['cpu_usage', 'disk_usage', 'memory_usage', 'network_sent', 'network_receive'];
//var fields = ['cpu_usage', 'disk_usage', 'memory_usage'];

var COMMIT_SAVE_COUNT = 200;


function LoadSvnStats () {
	$("#latex_commit_log").load('commitlist.html', function () {
		$("#latex_commit_log a.author").each(function() {
			$(this).replaceWith('<b>' + $(this).text() + '</b>');
		});
		$("#latex_commit_log a.permalink").each(function() {
			$(this).replaceWith($(this).text());
		});
	});

}

function LoadUserLines () {
	$("#users_lines tbody").load('user_lines.html');
}


function formatCommitBlob (d) {
	str = '<li>';
	str += '<div>' + d['user'] + ' committed</div>';
	str += '<div class="timeago" title="' + (new Date(d['time'])).toISOString() + '"></div>';
	str += '</li>';
	return str;
}

function updateTimeAgoDates () {
	$("#general_commit_log div.timeago").timeago();
}

function updateLinesGraph () {
	$("#lines_graph").attr("src", "svnstat/loc_per_author.png?"+(new Date()).getTime());
}

onload = function() {
	socket = io.connect('inductor.eecs.umich.edu:8080/stream');

	socket.on('connect', function (data) {
		var query = {$or: [{hostname  : 'nuclear.eecs.umich.edu'},
		                   {profile_id: '1ceFS5btOV'}]
		            };
		socket.emit('query', query);
	});

	socket.on('data', function (data) {

		if (data['profile_id'] == 'aWXe5FTVxu') {
			pdw = {};
			pd  = {};

			for (var i=0; i<fields.length; i++) {
				if (_.has(data, fields[i])) {
					pd[fields[i]] = [data['time']-14400000, data[fields[i]]];
				}
			}

			pdw = {name: data['hostname'], data:pd};
			g.addData(pdw);
			g.update();

		} else if (data['profile_id'] == '1ceFS5btOV') {
			$("#general_commit_log ul").children("li:gt(" + (COMMIT_SAVE_COUNT-1) + ")").remove();
			$("#general_commit_log ul").prepend(formatCommitBlob(data));
			updateTimeAgoDates();
		}

	});


	g = $.grapher($("#nuclear_graph"));


	LoadSvnStats();
	LoadUserLines();
	setInterval(LoadSvnStats, 300000);
	setInterval(updateLinesGraph, 300000);
	setInterval(updateTimeAgoDates, 30000);





}
