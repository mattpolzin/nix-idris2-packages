const readFileSync = require('node:fs').readFileSync
const execSync = require('node:child_process').execSync

const buffer = readFileSync(0)

const obj = JSON.parse(buffer)
const out = {}

for (packageName in obj) {
  const package = obj[packageName]
  const tag = 'latest:'
  const commit = package.commit.startsWith(tag) ? package.commit.slice(tag.length) : package.commit
  const prefetched = execSync(`nix-prefetch-git --url ${package.url} --rev ${commit} --quiet`)
  // can be useful debugging info:
  // console.error(prefetched.toString())
  const prefetchedJson = JSON.parse(prefetched)
  const hash = prefetchedJson.hash
  const path = prefetchedJson.path
  const ipkgExt = '.ipkg'
  const ipkgName = package.ipkg.endsWith(ipkgExt) ? package.ipkg.slice(0, -ipkgExt.length) : package.ipkg
  const ipkg = execSync(`idris2 --dump-ipkg-json ${path}/${ipkgName}.ipkg`)
  const ipkgJson = JSON.parse(ipkg)
  ipkgJson.depends = ipkgJson.depends.flatMap((d) => Object.keys(d))
  out[packageName] = { 
    packName: packageName, 
    ipkgName, 
    src: { url: package.url, rev: commit, hash },
    ipkgJson
  }
  console.error(`resolved hash of ${packageName} (src: ${path})`)
}

console.log(JSON.stringify(out))
