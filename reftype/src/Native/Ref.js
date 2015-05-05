Elm.Native.Ref = {};
Elm.Native.Ref.make = function(lr) {
    lr.Native = lr.Native || {};
    lr.Native.Ref = lr.Native.Ref || {};
    lr.Native.Ref.values = lr.Native.Ref.values || (function(Utils) {
        return {

            fieldSpec: function(name) {
                return {
                    get: function(o) {
                        return o[name];
                    },
                    set: function(v) {
                        return function(o) {
                            var c = Utils.copy(o);
                            c[name] = v;
                            return c;
                        };
                    }
                };
            }
            
        };
    })(Elm.Native.Utils.make(lr));
    return lr.Native.Ref.values;
};