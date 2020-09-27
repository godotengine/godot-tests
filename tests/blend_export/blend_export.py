# blender --background --python .\blend-export.py
import bpy
import posixpath
import shutil

blend = "32678-respect-import-hints-with-empty"
bpy.ops.wm.open_mainfile(filepath="blend/" + blend + ".blend")


export_type = "gltf"
shutil.rmtree(export_type, ignore_errors=True)
posixpath.os.mkdir(export_type, mode=0o777)
bpy.ops.export_scene.gltf(
    filepath=export_type + "/" + blend + ".gltf",
    export_format="GLTF_SEPARATE",
    export_copyright="The MIT License (MIT) Copyright (c) 2016 Godot Engine",
)


export_type = "obj"
shutil.rmtree(export_type, ignore_errors=True)
posixpath.os.mkdir(export_type, mode=0o777)
bpy.ops.export_scene.obj(filepath=export_type + "/" + blend + "." + export_type)


export_type = "fbx"
shutil.rmtree(export_type, ignore_errors=True)
posixpath.os.mkdir(export_type, mode=0o777)
bpy.ops.export_scene.fbx(filepath=export_type + "/" + blend + "." + export_type)