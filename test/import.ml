include Base
include Stdio
include Base_for_tests
include Expect_test_helpers_kernel

let () = Base.Not_exposed_properly.Int_conversions.sexp_of_int_style := `Underscores

let stage   = Staged.stage
let unstage = Staged.unstage

let ok_exn = Or_error.ok_exn

module type Hash = sig
  type t [@@deriving hash, sexp_of]
end

let check_hash_coherence (type t) here (module T : Hash with type t = t) ts =
  List.iter ts ~f:(fun t ->
    let hash1 = T.hash t in
    let hash2 = [%hash: T.t] t in
    require here (hash1 = hash2) ~cr:CR_soon
      ~if_false_then_print_s:
        (lazy [%message "" ~value:(t : T.t) (hash1 : int) (hash2 : int)]));
;;

module type Int_hash = sig
  include Hash
  val of_int_exn : int -> t
  val min_value : t
  val max_value : t
end

let check_int_hash_coherence (type t) here (module I : Int_hash with type t = t) =
  check_hash_coherence here (module I)
    [ I.min_value
    ; I.of_int_exn 0
    ; I.of_int_exn 37
    ; I.max_value ];
;;
