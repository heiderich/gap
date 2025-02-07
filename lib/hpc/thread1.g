#############################################################################
##
#W  thread1.g                    GAP library                 Chris Jefferson
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file provides trivial mocks of thread-related primitives for
##  traditional GAP.
##
##  The major design decision here it to make these mocks fast, rather than
##  try to make them as accurate as possible. For example, in HPC-GAP many
##  of these functions will perform an inernal copy of their argument,
##  which we do not do here.
##

# First we define some objects defined in init.g in HPC-GAP
BIND_GLOBAL("FILTER_REGION", "filter region");
BIND_GLOBAL("ThreadVar", rec());

# Now we mock functions from thread1.g

BIND_GLOBAL("MakeThreadLocal", ID_FUNC);
BIND_GLOBAL("MakeReadOnly", ID_FUNC);
BIND_GLOBAL("MakeReadOnlyRaw", ID_FUNC);
BIND_GLOBAL("MakeProtected", ID_FUNC);
BIND_GLOBAL("MakeProjectedObj", ID_FUNC);
BIND_GLOBAL("MakeReadOnlyObj", ID_FUNC);

BIND_GLOBAL("IsReadOnly", RETURN_FALSE);
BIND_GLOBAL("IsProtected", RETURN_FALSE);

BIND_GLOBAL("AtomicList", function(arg)
  local l, i;
  if LEN_LIST(arg) = 0 or LEN_LIST(arg) > 2 then
    Error("Invalid AtomicList arguments");
  fi;

  if LEN_LIST(arg) = 1 and IS_LIST(arg[1]) then
    l := [];
    for i in [1..LEN_LIST(arg[1])] do
      l[i] := arg[1][i];
    od;
    return l;
  fi;

  l := [];
  for i in [1..arg[1]] do
    l[i] := arg[2];
  od;
  return l;
end);

BIND_GLOBAL("FixedAtomicList", AtomicList);

BIND_GLOBAL("FromAtomicRecord", ID_FUNC);
BIND_GLOBAL("FromAtomicList", ID_FUNC);
BIND_GLOBAL("FromAtomicComObj", ID_FUNC);

BIND_GLOBAL("MakeStrictWriteOnceAtomic", ID_FUNC);
BIND_GLOBAL("MakeWriteOnceAtomic", ID_FUNC);

BIND_GLOBAL("AtomicRecord", function(arg)
  if LEN_LIST(arg) = 0 then
    return rec();
  fi;

  if LEN_LIST(arg) > 1 then
    Error("AtomicRecord takes one optional argument");
  fi;

  if not(IS_INT(arg[1]) or IS_REC(arg[1])) then
    Error("AtomicRecord takes an integer or record");
  fi;

  if IS_INT(arg[1]) then
    return rec();
  else
    return arg[1];
  fi;
end);

BIND_GLOBAL("BindThreadLocal", ASS_GVAR);

BIND_GLOBAL("BindThreadLocalConstructor", function(name, fun)
  local ret;
  # Catch if the function returns a value
  ret := CALL_WITH_CATCH(fun,[]);
  if LEN_LIST(ret) > 1 then
    ASS_GVAR(name, ret[2]);
  fi;
end);


# Convenience aliases

BIND_GLOBAL("IsShared", RETURN_TRUE);
BIND_GLOBAL("IsLockable", RETURN_TRUE);

BIND_GLOBAL("ShareObjWithPrecedence", RETURN_FIRST);


BIND_GLOBAL("ShareObj", RETURN_FIRST);
BIND_GLOBAL("ShareUserObj", RETURN_FIRST);
BIND_GLOBAL("ShareLibraryObj", RETURN_FIRST);
BIND_GLOBAL("ShareKernelObj", RETURN_FIRST);
BIND_GLOBAL("ShareInternalObj", RETURN_FIRST);
BIND_GLOBAL("ShareSpecialObj", RETURN_FIRST);
BIND_GLOBAL("ShareSingleObjWithPrecedence", RETURN_FIRST);
BIND_GLOBAL("ShareSingleObj", RETURN_FIRST); 
BIND_GLOBAL("ShareSingleLibraryObj", RETURN_FIRST);
BIND_GLOBAL("ShareSingleKernelObj", RETURN_FIRST);
BIND_GLOBAL("ShareSingleInternalObj", RETURN_FIRST);
BIND_GLOBAL("ShareSingleSpecialObj", RETURN_FIRST);


BIND_GLOBAL("MIGRATE", RETURN_FIRST);
BIND_GLOBAL("MIGRATE_RAW", RETURN_FIRST);
BIND_GLOBAL("MIGRATE_NORECURSE", RETURN_FIRST);
BIND_GLOBAL("ADOPT", ID_FUNC);
BIND_GLOBAL("ADOPT_NORECURSE", ID_FUNC);
BIND_GLOBAL("CLONE_REACHABLE", ID_FUNC);
BIND_GLOBAL("REACHABLE", ID_FUNC);

BIND_GLOBAL("MigrateObj", MIGRATE);
BIND_GLOBAL("MigrateSingleObj", MIGRATE_NORECURSE);
BIND_GLOBAL("AdoptObj", ADOPT);
BIND_GLOBAL("AdoptSingleObj", ADOPT_NORECURSE);
BIND_GLOBAL("CopyRegion", CLONE_REACHABLE);
BIND_GLOBAL("RegionSubObjects", REACHABLE);

BIND_GLOBAL("NewRegionWithPrecedence", function(arg1, precedence)
  return 0;
end);

BIND_GLOBAL("NewRegion", function(arg1)
  return 0;
end);

BIND_GLOBAL("NewLibraryRegion", NewRegion);
BIND_GLOBAL("NewKernelRegion", NewRegion);
BIND_GLOBAL("NewInternalRegion", NewRegion);
BIND_GLOBAL("NewSpecialRegion", NewRegion);

BIND_GLOBAL("LockAndMigrateObj", RETURN_FIRST);

BIND_GLOBAL("LockAndAdoptObj", ID_FUNC);

BIND_GLOBAL("IncorporateObj", function(target, index, value)
    if IS_PLIST_REP(target) then
      target[index] := target;
    elif IS_REC(target) then
      target.(index) := target;
    else
      Error("IncorporateObj: target must be plain list or record");
    fi;
end);

BIND_GLOBAL("AtomicIncorporateObj", IncorporateObj);

BIND_GLOBAL("CopyFromRegion", ID_FUNC);
BIND_GLOBAL("CopyToRegion", ID_FUNC);


###########################
# C methods

# From aobjects.c

BIND_GLOBAL("SetTLDefault", BindThreadLocal);
BIND_GLOBAL("SetTLConstructor", BindThreadLocalConstructor);

BIND_GLOBAL("ATOMIC_ADDITION", function(list, index, inc)
  list[index] := list[index] + inc;
  return list[index];
end);

BIND_GLOBAL("IS_ATOMIC_RECORD", IS_REC);

BIND_GLOBAL("GET_ATOMIC_RECORD", function(record, field, def)
  if IsBound(record.(field)) then
    return record.(field);
  else
    return def;
  fi;
end);

BIND_GLOBAL("SET_ATOMIC_RECORD", function(record, field, val)
  record.(field) := val;
  return val;
end);

BIND_GLOBAL("UNBIND_ATOMIC_RECORD", function(record, field)
  Unbind(record.(field));
end);

BIND_GLOBAL("ATOMIC_RECORD_REPLACEMENT", RETURN_NOTHING);
# From calls.c

BIND_GLOBAL("LOCKS_FUNC", RETURN_FAIL);
