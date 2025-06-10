const { exit } = require('node:process')

const readFileSync = require('node:fs').readFileSync
const execSync = require('node:child_process').execSync

const buffer = readFileSync(0)

const obj = JSON.parse(buffer)

function prefetch(url, commit) {
  const prefetched = execSync(`nix-prefetch-git --url ${url} --rev ${commit} --quiet`)
  // can be useful debugging info:
  // console.error(prefetched.toString())
  const prefetchedJson = JSON.parse(prefetched)
  const hash = prefetchedJson.hash
  const path = prefetchedJson.path
  return {hash, path}
}

// short circuit if just dealing with Idris2-LSP, not a list of packages
if (obj.ipkg && obj.ipkg.includes('idris2-lsp')) {
  const {hash, path} = prefetch(obj.url, obj.commit)
  const out = { name: "idris2", version: obj.version, src: { url: obj.url, rev: obj.commit, hash } }
  console.error(`resolved hash of idris2-lsp (src: ${path})`)
  console.log(JSON.stringify(out))
  exit(0)
}

// short circuit if just dealing with Idris2, not a list of packages
if (obj.version) {
  const {hash, path} = prefetch(obj.url, obj.commit)
  const out = { name: "idris2", version: obj.version, src: { url: obj.url, rev: obj.commit, hash } }
  console.error(`resolved hash of idris2 (src: ${path})`)
  console.log(JSON.stringify(out))
  exit(0)
}

const out = {}
for (packageName in obj) {
  const package = obj[packageName]
  const tag = 'latest:'
  const commit = package.commit.startsWith(tag) ? package.commit.slice(tag.length) : package.commit
  const ipkgExt = '.ipkg'
  const ipkgPath = package.ipkg.split("/")
  const ipkgDir = ipkgPath.slice(0,-1).join("/")
  const ipkgFilename = ipkgPath.slice(-1).join("/")
  const ipkgName = ipkgFilename.endsWith(ipkgExt) ? ipkgFilename.slice(0, -ipkgExt.length) : ipkgFilename
  const {hash, path} = prefetch(package.url, commit)
  const ipkg = execSync(`idris2 --dump-ipkg-json ${path}/${ipkgDir}/${ipkgName}.ipkg`)
  const ipkgJson = JSON.parse(ipkg)
  ipkgJson.depends = ipkgJson.depends.flatMap((d) => Object.keys(d))
  out[packageName] = { 
    packName: packageName, 
    ipkgName, 
    ipkgDir,
    src: { url: package.url, rev: commit, hash },
    ipkgJson
  }
  console.error(`resolved hash of ${packageName} (src: ${path})`)
}

console.log(JSON.stringify(out))
