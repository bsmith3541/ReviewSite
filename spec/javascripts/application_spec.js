//= require application.js
describe('AC', function() {
  it("should see nested form", function() {
    // var isac = $("<input id = "isac" type = "checkbox" value = 1></input>");
    spyOn($(document), "enableGraduatedCheckbox");
    expect($(document).enableGraduatedCheckbox).toHaveBeenCalled();
  });
});
