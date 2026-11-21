import Lean
open Lean
def main (args : List String) : IO UInt32 := do
  initSearchPath (← findSysroot)
  let modules := args.toArray.map (·.toName)
  let env ← importModules (modules.map ({ module := · })) {} (trustLevel := 1024)
  let wanted : Std.HashSet Name := Std.HashSet.ofArray modules
  let isTarget (n : Name) : Bool :=
    let s := n.toString
    s == "riemannZeta" || s == "DirichletCharacter.LFunction" || s == "NumberField.dedekindZeta"
      || s == "NumberField.HeckeCharacter.LSeries" || s == "LSeries" || s == "completedRiemannZeta"
      || s == "DirichletCharacter.completedLFunction"
  for (name, info) in env.constants.toList do
    let some idx := env.getModuleIdxFor? name | continue
    let m := env.header.moduleNames[idx.toNat]!
    unless wanted.contains m do continue
    let tHits := info.type.getUsedConstants.filter isTarget
    let vHits := (info.value?.map (·.getUsedConstants.filter isTarget)).getD #[]
    if tHits.size + vHits.size > 0 then
      IO.println s!"{name}\t{m}\tT:{tHits.toList}\tV:{vHits.toList}"
  return 0
