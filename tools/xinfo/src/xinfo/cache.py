'''
Caching utilities.
'''
import os
import pickle
import tempfile

CACHE_DIR = tempfile.gettempdir()

def _get_path(fname):
    '''
    Full path in the cache directory.
    '''
    return os.path.join(CACHE_DIR, fname)

def _load_object_from_file(fname):
    '''
    Read and return an object from the pickle data stored in a file.
    '''
    with open(_get_path(fname), 'rb') as fp:
        obj = pickle.load(fp)
        return obj

def _save_object_to_file(obj, fname):
    '''
    Write a pickled representation of obj to the open file object file.
    '''
    with open(_get_path(fname), 'wb') as fp:
        pickle.dump(obj, fp)

def _load_and_save(fname, func, *args):
    '''
    Call a func to save an object to a file cache. Return the object.
    '''
    obj = func(*args)
    _save_object_to_file(obj, fname)
    return obj

def _file_in_cache(fname):
    return os.path.isfile(_get_path(fname))

def lazy_load(fname, force, func, *args):
    '''
    Get an object from a file, or get it from the Oracle binary.
    '''
    if force:
        obj = _load_and_save(fname, func, *args)
    else:
        if _file_in_cache(fname):
            obj = _load_object_from_file(fname)
        else:
            obj = _load_and_save(fname, func, *args)
    return obj
