import io
import zlib
import sys

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

build_format = 'Build/{project_name} v{cur_version}.tosc'
build_name = build_format.format(project_name = sys.argv[1][0:-4], cur_version = version)

byteData = data.encode('UTF-8')
compressed = zlib.compress(byteData)

file = io.open(build_name, 'wb')
file.write(compressed)
file.close()