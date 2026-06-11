use std::time::Duration;

use chumsky::{
	Parser,
	prelude::*,
	text::{digits, ident, whitespace},
};

#[derive(Clone, Debug)]
pub enum MessageTree {
	Leaf(String),
	Command(Command),
	Named(String, Vec<MessageTree>),
}

#[derive(Clone, Debug)]
pub enum Command {
	Wait(Duration),
	Interval(Duration),
	Console(String),
	Hide(String),
	Show(String),
	Save(String),
	Load(String),
	Cursor {
		pos: [f64; 2],
		relative: bool,
	},
	Rect {
		rect: [f64; 4],
		relative: bool,
	},
	Icon(String),
	Face {
		actor: String,
		expr: String,
		scale: f64,
	},
	Replace {
		named_id: String,
		tree: Vec<MessageTree>,
	},
}

macro_rules! P {
    ($T:ty) => {
        impl Parser<'a, &'a str, $T, chumsky::extra::Err<Simple<'a, char>>> + Clone
    };
}

pub fn parse<'a>() -> P!(Vec<MessageTree>) {
	recursive(|r| {
		choice((
			none_of("{}%")
				.repeated()
				.at_least(1)
				.collect::<String>()
				.map(MessageTree::Leaf),
			just("%{")
				.ignore_then(ident().map(|i: &str| i.to_string()))
				.then_ignore(whitespace())
				.then(r.clone())
				.map(|(name, tree)| MessageTree::Named(name, tree))
				.then_ignore(just("}")),
			command(r.clone())
				.delimited_by(just('{'), just('}'))
				.map(MessageTree::Command),
		))
		.repeated()
		.collect()
	})
}

fn command<'a>(parse: P!(Vec<MessageTree>)) -> P!(Command) {
	choice((
		wait_cmd(),
		interval_cmd(),
		console_cmd(),
		hide_cmd(),
		show_cmd(),
		save_cmd(),
		load_cmd(),
		cursor_cmd(),
		rect_cmd(),
		icon_cmd(),
		face_cmd(),
		replace_cmd(parse),
	))
}

fn wait_cmd<'a>() -> P!(Command) {
	just("wait")
		.then(whitespace())
		.ignore_then(float().map(Duration::from_secs_f64))
		.map(Command::Wait)
}

fn interval_cmd<'a>() -> P!(Command) {
	just("interval")
		.then(whitespace())
		.ignore_then(float().map(Duration::from_secs_f64))
		.map(Command::Interval)
}

fn console_cmd<'a>() -> P!(Command) {
	just("console")
		.then(whitespace())
		.ignore_then(string())
		.map(Command::Console)
}

fn hide_cmd<'a>() -> P!(Command) {
	just("hide")
		.then(whitespace())
		.ignore_then(ident().map(|i: &str| i.to_string()))
		.map(Command::Hide)
}

fn show_cmd<'a>() -> P!(Command) {
	just("show")
		.then(whitespace())
		.ignore_then(ident().map(|i: &str| i.to_string()))
		.map(Command::Show)
}

fn save_cmd<'a>() -> P!(Command) {
	just("save")
		.then(whitespace())
		.ignore_then(ident().map(|i: &str| i.to_string()))
		.map(Command::Save)
}

fn load_cmd<'a>() -> P!(Command) {
	just("load")
		.then(whitespace())
		.ignore_then(ident().map(|i: &str| i.to_string()))
		.map(Command::Load)
}

fn cursor_cmd<'a>() -> P!(Command) {
	just("cursor")
		.then(whitespace())
		.ignore_then(
			float()
				.separated_by(whitespace())
				.exactly(2)
				.collect::<Vec<_>>(),
		)
		.then(whitespace().ignore_then(just("rel")).or_not())
		.map(|(bounds, rel)| Command::Cursor {
			pos: bounds.try_into().unwrap(),
			relative: rel.is_some(),
		})
}

fn rect_cmd<'a>() -> P!(Command) {
	just("rect")
		.then(whitespace())
		.ignore_then(
			float()
				.separated_by(whitespace())
				.exactly(4)
				.collect::<Vec<_>>(),
		)
		.then(whitespace().ignore_then(just("rel")).or_not())
		.map(|(bounds, rel)| Command::Rect {
			rect: bounds.try_into().unwrap(),
			relative: rel.is_some(),
		})
}

fn icon_cmd<'a>() -> P!(Command) {
	just("icon")
		.then(whitespace())
		.ignore_then(ident().map(|i: &str| i.to_string()))
		.map(Command::Icon)
}

fn face_cmd<'a>() -> P!(Command) {
	just("face")
		.ignore_then(
			whitespace()
				.ignore_then(ident())
				.repeated()
				.exactly(2)
				.collect::<Vec<_>>(),
		)
		.then(float().or_not().map(|f| f.unwrap_or(1.)))
		.map(|(args, scale)| Command::Face {
			actor: args[0].to_string(),
			expr: args[1].to_string(),
			scale,
		})
}

fn replace_cmd<'a>(parse: P!(Vec<MessageTree>)) -> P!(Command) {
	just("replace")
		.then(whitespace())
		.ignore_then(ident().map(|i: &str| i.to_string()))
		.then_ignore(whitespace())
		.then(parse)
		.map(|(id, tree)| Command::Replace { named_id: id, tree })
}

fn float<'a>() -> P!(f64) {
	just('-')
		.or_not()
		.map(|minus| minus.is_some())
		.then(digits(10).at_least(1).collect::<String>())
		.then(
			just('.')
				.ignore_then(digits(10).collect::<String>())
				.or_not(),
		)
		.map(|((neg, whole), decimal)| {
			format!(
				"{}{whole}.{}",
				if neg { "-" } else { "" },
				decimal.as_deref().unwrap_or("0")
			)
			.parse()
			.unwrap()
		})
}

fn string<'a>() -> P!(String) {
	choice((none_of("\""), just("\\\\").to('\\'), just("\\\"").to('\"')))
		.repeated()
		.collect::<String>()
		.delimited_by(just('"'), just('"'))
}

#[test]
fn test_rect() {
	let str = "{rect 0 1 0 0.45}I'm on the left!{rect 0 1 0.55 1}And I'm on the right.{rect 0.5 1 0 1 rel}I'm halfway down the right side.";
	let parsed = parse().parse(str).unwrap();
	dbg!(parsed);
}

#[test]
fn test_replace() {
	let str = "Hello, %{foo Mars...}{wait 2}{replace foo World!}";
	let parsed = parse().parse(str).unwrap();
	dbg!(parsed);
}
