package funkin.states.editors.ui;

class EditorNote extends funkin.objects.note.Note {
	public var chartData:Array<Dynamic> = null;
	
	public var selected:Bool = false;
	
	public override function destroy():Void {
		chartData = null;
		
		super.destroy();
	}
}