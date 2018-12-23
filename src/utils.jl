const AbstractDataset = Union{Dataset, DDataset}

isquotenode(::Any) = false
isquotenode(::QuoteNode) = true

ispair(::Any) = false
ispair(x::Expr) = length(x.args) >=1 && x.args[1] == :(=>)

istuple(::Any) = false
istuple(x::Expr) = x.head == :tuple

parse_function_call(args...) = parse_function_call!([], args...)

parse_function_call!(syms, d, x, func, args...) =
    _parse_function_call!(syms, d, helper_namedtuples_replacement(x), func, args...)

function _parse_function_call!(syms, d, x, func, args...)
    if x == :(_)
        push!(syms, x)
        func(d, args...)
    else
        x
    end
end

function _parse_function_call!(syms, d, x::QuoteNode, func, args...)
    push!(syms, x)
    func(d, x, args...)
end

function _parse_function_call!(syms, d, x::Expr, func, args...)
    if x.head == :. && length(x.args) == 2 && isquotenode(x.args[2])
        Expr(x.head, _parse_function_call!(syms, d, x.args[1], func, args...), x.args[2])
    elseif x.head == :call && length(x.args) == 2 && x.args[1] == :^
            x.args[2]
    elseif x.head == :call && x.args[1] == :cols
        push!(syms, x.args[2])
        func(d, x.args[2], args...)
    else
        Expr(x.head, (_parse_function_call!(syms, d, arg, func, args...) for arg in x.args)...)
    end
end

function extract_anonymous_function(x, func, args...; usekey = false)
    syms = Any[]
    key = gensym()
    data = gensym()
    function_call = parse_function_call!(syms, data, usekey ? replace_key(key, x) : x, func, args...)
    anon_func = usekey ? Expr(:(->), Expr(:tuple, key, data), function_call) :
        Expr(:(->), data, function_call)
    return anon_func, unique(syms)
end

function replace_key(key, ex)
    MacroTools.postwalk(ex) do x
        if x == Expr(:., :(_), QuoteNode(:key))
            return key
        else
            return x
        end
    end
end

# From Query: use curly brackets to simplify writing named tuples
function helper_namedtuples_replacement(ex)
	MacroTools.postwalk(ex) do x
		if x isa Expr && x.head==:braces
			new_ex = Expr(:tuple, x.args...)

			for (j,field_in_NT) in enumerate(new_ex.args)
				if isa(field_in_NT, Expr) && field_in_NT.head==:(=)
					new_ex.args[j] = Expr(:(=), field_in_NT.args...)
				elseif isquotenode(field_in_NT)
					new_ex.args[j] = Expr(:(=), field_in_NT.value, field_in_NT)
                elseif isa(field_in_NT, Expr)
                    new_ex.args[j] = Expr(:(=), Symbol(filter(t -> t != ':', string(field_in_NT))), field_in_NT)
                elseif isa(field_in_NT, Symbol)
                   new_ex.args[j] = Expr(:(=), field_in_NT, field_in_NT)
                end
			end

			return new_ex
		else
			return x
		end
	end
end

replace_keyword(arg) = (@capture arg x_ = y_) ? Expr(:kw, x, y) : arg

replace_keywords(args) = map(replace_keyword, args)

_table(cols::C) where{C<:Columns} = 
        IndexedTable{C}(cols, Int[], IndexedTables.Perm[], fill(missing, length(cols)), nothing)
_table(c) = c

distinct_tuple(args...) = Tuple(IterTools.distinct(args))
