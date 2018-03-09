const AbstractDataset = Union{IndexedTables.AbstractNDSparse, IndexedTables.AbstractIndexedTable}

isquotenode(::Any) = false
isquotenode(x::Expr) = x.head == :quote

parse_function_call(args...) = parse_function_call!(Symbol[], args...)

function parse_function_call!(syms, d, x, func, args...)
    if x == :(_)
        push!(syms, x)
        d
    else
        x
    end
end

function parse_function_call!(syms, d, x::Expr, func, args...)
    if x.head == :. && length(x.args) == 2 && isquotenode(x.args[2])
        Expr(x.head, parse_function_call!(syms, d, x.args[1], func, args...), x.args[2])
    elseif x.head == :quote
        push!(syms, x.args[1])
        func(d, x, args...)
    elseif x.head == :call && length(x.args) == 2 && x.args[1] == :^
        x.args[2]
    else
        Expr(x.head, (parse_function_call!(syms, d, arg, func, args...) for arg in x.args)...)
    end
end

function extract_anonymous_function(x, func)
    syms = Symbol[]
    iter = gensym()
    function_call = parse_function_call!(syms, iter, x, func)
    Expr(:(->), iter, function_call), unique(syms)
end

# From Query: use curly brackets to simplify writing named tuples
function helper_namedtuples_replacement(ex)
	MacroTools.postwalk(ex) do x
		if x isa Expr && x.head==:cell1d
			new_ex = Expr(:macrocall, Symbol("@NT"), x.args...)

			for (j,field_in_NT) in enumerate(new_ex.args[2:end])
				if isa(field_in_NT, Expr) && field_in_NT.head==:(=)
					new_ex.args[j+1] = Expr(:kw, field_in_NT.args...)
				elseif isquotenode(field_in_NT)
					new_ex.args[j+1] = Expr(:kw, field_in_NT.args[1], field_in_NT)
                elseif isa(field_in_NT, Expr)
                    new_ex.args[j+1] = Expr(:kw, Symbol(filter(t -> t != ':', string(field_in_NT))), field_in_NT)
                elseif isa(field_in_NT, Symbol)
                   new_ex.args[j+1] = Expr(:kw, field_in_NT, field_in_NT)
                end
			end

			return new_ex
		else
			return x
		end
	end
end
