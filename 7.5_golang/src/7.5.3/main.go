package main

import "fmt"

func main() {
    var x []int
    for y := 3; y <= 100; y = y + 3 {
        x = append(x, y)
    }
    fmt.Println(x)
}
