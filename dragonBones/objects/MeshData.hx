package dragonBones.objects
{
import openfl.geom.Matrix;

import dragonBones.core.BaseObject;

/**
 * @private
 */
public final class MeshData extends BaseObject
{
	public var skinned:Bool;
	public var name:String;
	public inline var slotPose:Matrix = new Matrix();
	
	public inline var uvs:Vector<Float> = new Vector<Float>(); // vertices * 2
	public inline var vertices:Vector<Float> = new Vector<Float>(); // vertices * 2
	public inline var vertexIndices:Vector<UInt> = new Vector<UInt>(); // triangles * 3
	
	public inline var boneIndices:Vector<Vector<UInt>> = new Vector<Vector<UInt>>(); // vertices bones
	public inline var weights:Vector<Vector<Float>> = new Vector<Vector<Float>>(); // vertices bones
	public inline var boneVertices:Vector<Vector<Float>> = new Vector<Vector<Float>>(); // vertices bones * 2
	
	public inline var bones:Vector<BoneData> = new Vector<BoneData>(); // bones
	public inline var inverseBindPose:Vector<Matrix> = new Vector<Matrix>(); // bones
	
	public function MeshData()
	{
		super(this);
	}
	
	override private function _onClear():Void
	{
		skinned = false;
		name = null;
		slotPose.identity();
		uvs.fixed = false;
		uvs.length = 0;
		vertices.fixed = false;
		vertices.length = 0;
		vertexIndices.fixed = false;
		vertexIndices.length = 0;
		boneIndices.fixed = false;
		boneIndices.length = 0;
		weights.fixed = false;
		weights.length = 0;
		boneVertices.fixed = false;
		boneVertices.length = 0;
		bones.fixed = false;
		bones.length = 0;
		inverseBindPose.fixed = false;
		inverseBindPose.length = 0;
	}
}
}