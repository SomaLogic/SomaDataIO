
test_that("addClass() adds the class label to the object", {
  x <- addClass(mtcars, "foo")
  expect_equal(class(x), c("foo", "data.frame"))
  expect_equal(class(addClass(x, "foo")), class(x))   # no change

  expect_equal(
    class(addClass(mtcars, c("foo", "foo"))),  # no duplicates
    c("foo", "data.frame")
  )
  expect_equal(
    class(addClass(mtcars, c("foo", "bar"))), # multiple classes
    c("foo", "bar", "data.frame")
  )
  expect_equal(
    class(addClass(mtcars, c("bar", "foo"))), # multiple classes in order
    c("bar", "foo", "data.frame")
  )

  expect_equal(
    class(addClass(x, "data.frame")), c("data.frame", "foo") # re-orders
  )

  expect_warning(
    expect_equal(class(addClass(mtcars, NULL)), "data.frame"), # NULL case no change
    "Passing `class = NULL` leaves class(x) unchanged.",
    fixed = TRUE
  )
  expect_warning(
    expect_equal(class(addClass(x, NULL)), class(x)),  # NULL case no change
    "Passing `class = NULL` leaves class(x) unchanged.",
    fixed = TRUE
  )

  expect_error(
    addClass(mtcars, NA_character_),
    "The `class` param cannot contain `NA`: NA"
  )
  expect_error(
    addClass(mtcars, c("foo", NA_character_)),
    "The `class` param cannot contain `NA`: 'foo', NA"
  )
})
