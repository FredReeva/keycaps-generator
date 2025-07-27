#!/usr/bin/env python3
import zipfile
import os
import shutil
from xml.etree import ElementTree as ET

NAMESPACE = {'m': 'http://schemas.microsoft.com/3dmanufacturing/core/2015/02'}

def unzip_3mf(source, dest):
    with zipfile.ZipFile(source, 'r') as zip_ref:
        zip_ref.extractall(dest)

def zip_3mf(source_folder, output_file):
    with zipfile.ZipFile(output_file, 'w', zipfile.ZIP_DEFLATED) as zip_out:
        for foldername, _, filenames in os.walk(source_folder):
            for filename in filenames:
                filepath = os.path.join(foldername, filename)
                arcname = os.path.relpath(filepath, source_folder)
                zip_out.write(filepath, arcname)

def merge_3mf(base_path, text_path, output_path):
    shutil.rmtree("intermediates", ignore_errors=True)
    os.makedirs("intermediates/base")
    os.makedirs("intermediates/text")
    os.makedirs("intermediates/merged")

    unzip_3mf(base_path, "intermediates/base")
    unzip_3mf(text_path, "intermediates/text")

    base_model = ET.parse("intermediates/base/3D/3dmodel.model")
    base_root = base_model.getroot()
    base_object = base_root.findall(".//m:object", NAMESPACE)[0]
    base_id = int(base_object.attrib['id'])

    text_model = ET.parse("intermediates/text/3D/3dmodel.model")
    text_root = text_model.getroot()
    text_object = text_root.findall(".//m:object", NAMESPACE)[0]
    text_id = int(text_object.attrib['id'])

    next_id = max(base_id, text_id) + 1
    text_object.attrib['id'] = str(next_id)
    text_id = next_id

    base_object.attrib['name'] = "Base"
    text_object.attrib['name'] = "Text"

    resources = base_root.find("m:resources", NAMESPACE)
    if resources is None:
        resources = ET.SubElement(base_root, f"{{{NAMESPACE['m']}}}resources")

    ET.SubElement(resources, f"{{{NAMESPACE['m']}}}basematerial", {"id": "3"}).append(
        ET.Element(f"{{{NAMESPACE['m']}}}material", {"color": "#222222", "name": "BaseBlack"})
    )
    ET.SubElement(resources, f"{{{NAMESPACE['m']}}}basematerial", {"id": "1"}).append(
        ET.Element(f"{{{NAMESPACE['m']}}}material", {"color": "#FFFFFF", "name": "TextWhite"})
    )

    base_object.set("pid", "3")
    text_object.set("pid", "1")

    parent_id = str(max(base_id, text_id) + 1)
    group_object = ET.Element(f"{{{NAMESPACE['m']}}}object", {
        "id": parent_id,
        "type": "model",
        "name": "MergedPart"
    })

    components = ET.SubElement(group_object, f"{{{NAMESPACE['m']}}}components")
    ET.SubElement(components, f"{{{NAMESPACE['m']}}}component", {"objectid": str(base_id)})
    ET.SubElement(components, f"{{{NAMESPACE['m']}}}component", {"objectid": str(text_id)})

    base_root.append(text_object)
    base_root.append(group_object)

    build_node = base_root.find("m:build", NAMESPACE)
    if build_node is not None:
        base_root.remove(build_node)
    build_node = ET.SubElement(base_root, f"{{{NAMESPACE['m']}}}build")
    ET.SubElement(build_node, f"{{{NAMESPACE['m']}}}item", {"objectid": parent_id})format

    ET.register_namespace('', NAMESPACE['m'])

    shutil.copy(
        os.path.join("intermediates/base", "[Content_Types].xml"),
        os.path.join("intermediates/merged", "[Content_Types].xml")
    )

    rels_src = os.path.join("intermediates/base", "_rels", ".rels")
    rels_dst_dir = os.path.join("intermediates/merged", "_rels")
    os.makedirs(rels_dst_dir, exist_ok=True)
    shutil.copy(rels_src, os.path.join(rels_dst_dir, ".rels"))

    os.makedirs("intermediates/merged/3D", exist_ok=True)
    base_model.write("intermediates/merged/3D/3dmodel.model", encoding='utf-8', xml_declaration=True)

    zip_3mf("intermediates/merged", output_path)
    print(f"🎯 Final .3mf with grouped subobjects saved as '{output_path}'!")

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 4:
        print("Usage: python merge_3mf.py base.3mf text.3mf output.3mf")
        sys.exit(1)
    merge_3mf(sys.argv[1], sys.argv[2], sys.argv[3])
