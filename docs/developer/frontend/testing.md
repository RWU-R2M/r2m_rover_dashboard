# Frontend Testing Guide

Strategy, tools, and practices for frontend tests.

## General Testing Philosophy
- **Focus on Behavior**: Test what the user sees and interacts with.
- **Integration > Isolation**: Prefer component/integration tests over tiny unit tests, ensuring parts work together.
- **Maintainable**: Write clear tests.
- **Prevent Regressions**: Add tests for bugs that you just fixed, so they don't happen again.


## Running Tests
1.  **npm (in `frontend/` dir):**
    ```bash
    npm run test         
    ```
OR:

2.  **`manage.sh` (in project root):**
    ```bash
    ./manage.sh test-frontend
    ```

## Simple Test Info (from a Backend Dev)

I'm not a frontend developer and don't know much about frontend testing.  
But here's what I came up with:

- Test files are named like `something.test.js` and live next to the code.
- Most tests check if functions or components work as expected.
- To run tests, use the commands above.
- If you add new code, try to add simple tests that checks if it works (functionality/behavior oriented).

For more details, check the existing `.test.js` files.
