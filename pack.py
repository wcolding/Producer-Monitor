import io
import zlib
import sys
from configparser import ConfigParser
import xml.etree.ElementTree as ET

if (len(sys.argv) < 2):
    print('Expected argument\nUsage: "python pack.py xmlFileName"')
    exit()

version = '3.0'

file = io.open(sys.argv[1], 'r')
data = file.read()
file.close()

replacements = 0
startIndex = 0
endIndex = 0
luaName = ''
luaScript = ''
submoduleStart = 0
submoduleNext = 0
submoduleName = ''
submoduleScript = ''
start = ''
end = ''

while startIndex != -1:
    startIndex = data.find('${')
    if startIndex > -1:
        endIndex = data.find('}', startIndex)
        luaName = data[startIndex + 2 : endIndex]
        print(f'Reference found: \'{luaName}\'')

        try:
            luaFile = io.open(f'Lua/{luaName}', 'r')
            luaScript = luaFile.read()
            luaFile.close()
        except:
            print(f'Unable to open file \'{luaName}\'')
            print('Could not complete packing! Closing...')
            exit()

        # Check luaScript for submodules
        while submoduleStart != -1:
            submoduleStart = luaScript.find('--Submodule.include(\'')
            if submoduleStart > -1:
                start = luaScript[0 : submoduleStart]
                end = luaScript[submoduleStart + 21 :]
                submoduleNext = end.find('\')')
                submoduleName = end[0:submoduleNext]
                if submoduleNext > -1:
                    print(f'Found submodule reference: \'{submoduleName}\'')
                    
                    try:
                        luaFile = io.open(f'Lua/Submodules/{submoduleName}', 'r')
                        submoduleScript = luaFile.read()
                        luaFile.close()
                    except:
                        print(f'Unable to open submodule file \'{submoduleName}\'')
                        print('Could not complete packing! Closing...')
                        exit()
                    
                    luaScript = luaScript.replace(f'--Submodule.include(\'{submoduleName}\')', submoduleScript)
                    replacements += 1

        # Insert luaScript into XML 
        start = data[0 : startIndex]
        end = data[endIndex + 1 :]
        data = f'{start}<![CDATA[{luaScript}]]>{end}'
        replacements += 1

print(f'Total replacements: {replacements}')

build_config = ConfigParser()
build_config.read('builds.ini')
sections = build_config.sections()
print(f'Build configurations found: {sections}\n')

if len(sections) > 0:
    for section in sections:
        build_name = f'Build/{sys.argv[1][0:-4]} ({section}) v{version}.tosc'
        temp_data = data

        print(section)
        
        # Replace string '$BUILD_NAME' with actual build name. This can automate relabeling things
        temp_data = temp_data.replace('$BUILD_NAME', section)

        root = ET.fromstring(temp_data)
        properties = build_config[section].items()
        for property in properties: 
            xmlProperties = root.findall(".//property")
            for p in xmlProperties:
                if p[0].text == property[0].upper():
                    print(f'Found {p[0].text}')
                    print(f'Replacing value "{p[1].text}" with "{property[1]}"')
                    p[1].text = property[1]
        
        build_data = ET.tostring(root)
        compressed = zlib.compress(build_data)

        file = io.open(build_name, 'wb')
        file.write(compressed)
        file.close()
        print(f'Wrote to {build_name}')
        print('----')
else:
    build_name = f'Build/{sys.argv[1][0:-4]} v{version}.tosc'
    build_data = data.encode('UTF-8')
    compressed = zlib.compress(build_data)
    
    file = io.open(build_name, 'wb')
    file.write(compressed)
    file.close()
    print(f'Wrote to {build_name}')
    print('----')