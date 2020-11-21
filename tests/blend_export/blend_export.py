# blender --background --python .\blend_export.py
import bpy
import posixpath
import shutil
import os

directories = ["blend", "proposal/blend"]
export_types = ["gltf", "obj", "fbx"]
for export_type in export_types:
    shutil.rmtree(export_type, ignore_errors=True)
    posixpath.os.mkdir(export_type, mode=0o777)
for directory in directories:
    for filename in os.listdir(directory):
        if not filename.endswith(".blend"):
            continue
        for export_type in export_types:
            bpy.ops.wm.open_mainfile(filepath=os.path.join(directory, filename))
            basename = filename.rsplit(".blend", 1)[0]
            export_path = os.path.normpath(os.path.join(directory, os.pardir, export_type, basename + "." + export_type))
            if export_type == "gltf":
                bpy.ops.export_scene.gltf(
                    filepath=export_path,
                    export_format="GLTF_SEPARATE",
                    export_copyright="The MIT License (MIT) Copyright (c) 2020 Godot Engine",
                )
            elif export_type == "fbx":
                bpy.ops.export_scene.fbx(filepath=export_path)
            elif export_type == "obj":
                bpy.ops.export_scene.obj(filepath=export_path)
