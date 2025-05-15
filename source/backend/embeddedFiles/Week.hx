package backend.embeddedFiles;

enum abstract Week(String) from String to String {
    var episode1:String = '{
	"songs": [
		["Devilish Deal", "mick-isolated-new", [129, 100, 233]],
		["Isolated", "mick-isolated-new", [129, 100, 233]],
		["Lunacy", "lunamick-new", [129, 100, 233]],
		["Delusional", "insanemick", [129, 100, 233]]
	],

	"weekCharacters": [
		"",
		"bf",
		"gf"
	],
	"weekBackground": "stage",

	"attachedImage": "episode1",
	"storyName": "Broken Relationship",
	"weekBefore": "tutorial",
	"weekName": "Episode 1",
	"startUnlocked": true,

	"hideStoryMode": false,
	"hideFreeplay": false
}';

var episode1Evil:String = '{
	"songs": [
		["Devilish Deal", "mick-isolated-new", [129, 100, 233]],
		["Isolated", "mick-isolated-new", [129, 100, 233]],
		["Lunacy", "lunamick-new", [129, 100, 233]],
		["Delusional", "insanemick", [129, 100, 233]]
	],

	"weekCharacters": [
		"",
		"bf",
		"gf"
	],
	"weekBackground": "stage",

	"attachedImage": "episode1",
	"storyName": "Satanic Heartbreak",
	"weekBefore": "tutorial",
	"weekName": "Episode 1",
	"startUnlocked": true,

	"hideStoryMode": false,
	"hideFreeplay": false
}';

    var placeholderWeek:String = '{
	"songs": [
		["Test", "face", [129, 100, 233]]
	],

	"weekCharacters": [
		"",
		"bf",
		"gf"
	],
	"weekBackground": "stage",

	"attachedImage": "episode0",
	"storyName": "MISSING WEEK",
	"weekBefore": "tutorial",
	"weekName": "Tutorial",
	"startUnlocked": true,

	"hideStoryMode": false,
	"hideFreeplay": false
}';
}