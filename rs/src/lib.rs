use godot::init::{ExtensionLibrary, gdextension};

mod message;

struct Ext;

#[gdextension]
unsafe impl ExtensionLibrary for Ext {}
