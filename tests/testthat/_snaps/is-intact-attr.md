# user defined `verbose =` param overrides internal logic as expected

    Code
      is_intact_attr(iris, verbose = TRUE)
    Message
      x The object is not a `soma_adat` class object: "data.frame"
    Output
      [1] FALSE

---

    Code
      is_intact_attr(iris, verbose = FALSE)
    Output
      [1] FALSE

# verbosity is triggered only when called directly

    Code
      is_intact_attr(iris)
    Message
      x The object is not a `soma_adat` class object: "data.frame"
    Output
      [1] FALSE

---

    Code
      f1(iris)
    Output
      [1] FALSE

---

    Code
      f2(iris)
    Output
      [1] FALSE

