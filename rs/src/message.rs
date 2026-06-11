use std::str::FromStr;

use crate::message::parser::MessageTree;
use chumsky::Parser;
use godot::prelude::*;

#[derive(GodotClass)]
#[class(no_init)]
/// A parsed message.
pub struct RMessage {
	#[export]
	speaker: GString,
	tree: Vec<MessageTree>,
	base: Base<RefCounted>,
}

#[godot_api]
impl RMessage {
	#[func]
	fn from_str(str: GString, tags: Array<GString>) -> Option<Gd<Self>> {
		let str = str.to_string();
		let (name, rest) = str.split_once(": ")?;
		let tree = match parser::parse().parse(rest).into_result() {
			Ok(v) => v,
			Err(e) => {
				for e in e {
					godot_error!("Message error:\n{e}");
				}
				vec![MessageTree::Leaf(
					"Malformed message! Check console.".to_string(),
				)]
			}
		};
		Some(Gd::from_init_fn(|base| Self {
			base,
			tree,
			speaker: GString::from_str(name).unwrap(),
		}))
	}
}

mod parser;
