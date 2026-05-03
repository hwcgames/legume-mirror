import * as ink from 'npm:inkjs/full'

var story_file = await Deno.readTextFile('../story/test/main.ink')
var story = new ink.Compiler(story_file, new ink.PosixFileHandler('../story/test')).Compile();

const turn_limit = 1000

var frontier = []

var lines = {}

frontier.push(story.state.ToJson())

while (frontier.length > 0) {
    story.state.LoadJson(frontier.pop())
}